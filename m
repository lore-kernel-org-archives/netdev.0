From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 3/6][8021q][2.4] Use VLAN tag set functionality in 8021q
 module
Date: Mon, 26 Jan 2004 12:42:53 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4015519D.5080803@pobox.com>
References: <E791C176A6139242A988ABA8B3D9B38A02A46612@hasmsx403.iil.intel.com> <200401261522.14126.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Shmuel Hen <shmulik.hen@intel.com>
In-Reply-To: <200401261522.14126.shmulik.hen@intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Shmuel Hen wrote:
> Also, speaking of the bonding changes queued in netdev-2.4, some of
> those have been queued there since 2.4.23 came out. Will those be
> pushed to Marcelo during 2.4.25 or do you intend to hold them until
> 2.4.26-preX starts?


Sounds like DaveM and I will need to coordinate a bit, then.

Queued bonding stuff for 2.4:  Marcelo wanted to wait until 2.4.25 
release, so they will go to Marcelo for 2.4.26-pre1.

Queued bonding stuff for 2.6:  Similar picture.  Waiting for 2.6.2 
release, then it goes to Andrew/Linus.

Note that at some point, IMO you need to plan on 2.6-only development, 
since keeping bonding the same in 2.4 and 2.6 -through ABI changes- may 
not be feasible past the short term.  2.4 developmnent is intentionally 
slowing down on Marcelo's side, even though vendors are still shipping 
2.4.x stuff.

	Jeff
