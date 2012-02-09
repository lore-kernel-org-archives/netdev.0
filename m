From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: Re: [RFC][PATCH 00/50] set addr_assign_type to NET_ADDR_RANDOM if a random mac address get assigned to a netdevice
Date: Thu, 9 Feb 2012 13:18:35 +0100
Message-ID: <201202091318.36264.danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <20120208.182942.1223790992368933837.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120208.182942.1223790992368933837.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Donnerstag, 9. Februar 2012, David Miller wrote:
> 50 patches is way too many patches to submit and expect people
> to review at one time.
>
> You must do one of two things:
>
> 1) Condense the series down to a smaller number of more managable
>    patches.  Perhaps combine all the completely trivial conversion
>    cases into one single patch, and post the non-trivial cases
>    seperately.
>
> 2) Only submit a few of these changes at a time, not all at once.
>
> It's your choice, but what you did here is unacceptable.

Could you at least comment on these points from the cover letter, before I 
change/update the patches?

- Should NET_ADDR_RANDOM get reset (to NET_ADDR_PERM) if the MAC address
  get changed via SIOCSIFHWADDR/.ndo_set_mac_address and was random before?
- Would it make sense to add a new state (e.g. NET_ADDR_USERSPACE)
  if the net address get changed via SIOCSIFHWADDR/.ndo_set_mac_address 
  from userspace?

Thanks,

Danny
