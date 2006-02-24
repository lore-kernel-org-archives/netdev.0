From: Wolfgang Hoffmann <woho@woho.de>
Subject: Re: [git patches] net driver fixes
Date: Fri, 24 Feb 2006 18:28:40 +0100
Message-ID: <200602241828.40383.woho@woho.de>
References: <20060224052214.GA14586@havoc.gtf.org> <200602240859.23062.woho@woho.de> <43FF30D1.8060708@osdl.org>
Reply-To: woho@woho.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932400AbWBXR10@vger.kernel.org>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <43FF30D1.8060708@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 24 February 2006 17:14, Stephen Hemminger wrote:
> There is an outstanding bug where the sky2 will hang if it receives a
> packet larger than the MTU.  At this point, there isn't enough information
> on chip behavior to fix.
>
> You could try using a larger mut or patching the driver so that the
> rx_buffer_size is always big (like 4k).

I've raised the MTU from 1500 to 3000 and still reproduced the hang. Would you 
mind sending me a patch for forcing rx_buffer_size to 4k, so I can try that, 
or is no sense in that, given that raising the MTU didn't help?

Concerning information on chip behavior, are you missing vendor specs, or 
could I be helpful by reproducing the hang with an instrumented driver that 
gives more information about the chip status at hang time?

Another thing that may be worth to find out is why 0.13 with Carl-Daniel 
Hailfingers fix works. I didn't see a single hang with that version. I'm 
currently resorting to that version, but well ...

I'd really like to help get this driver working robustly. I'm not enough into 
networking to help by coding, but yes I'll give feedback on any driver 
version you send me. I'd just like to provide you more helpful data than 
repeating "new version still hangs" ;-)

Wolfgang
