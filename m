From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH V3 0/8] macvtap/vhost TX zero copy support
Date: Fri, 22 Apr 2011 10:31:48 -0700
Message-ID: <1303493508.10632.2.camel@localhost.localdomain>
References: <1303328216.19336.18.camel@localhost.localdomain>
	 <BANLkTi=ckukmCdOOvQc29vtYgxeiSMGqBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, mst@redhat.com,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jon Mason <jdmason@kudzu.us>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <BANLkTi=ckukmCdOOvQc29vtYgxeiSMGqBw@mail.gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2011-04-21 at 10:29 -0400, Jon Mason wrote:
> Why are only these 3 drivers getting support?  As far as I can tell,
> the only requirement is HIGHDMA.  If this is the case, is there really
> a need for an additional flag to support this?  If you can key off of
> HIGHDMA, all devices that support this would get the benefit.

Agreed. So far, I have only verified these three 10Gb NICs we have in
our lab. We can enable all devices which support HIGHDMA.

Thanks
Shirley

