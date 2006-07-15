From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/7] NetLabel: core network changes
Date: Sat, 15 Jul 2006 10:48:02 -0400
Message-ID: <200607151048.02921.paul.moore@hp.com>
References: <20060714185739.780700000@flek.zko.hp.com> <20060714185914.416432000@flek.zko.hp.com> <Pine.LNX.4.64.0607141933170.18747@d.namei>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov,
	"David S. Miller" <davem@davemloft.net>, sds@epoch.ncsc.mil,
	pratt@argus-systems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.cce.hp.com ([161.114.21.23]:62620 "EHLO
	ccerelrim02.cce.hp.com") by vger.kernel.org with ESMTP
	id S1161176AbWGOOtL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 10:49:11 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0607141933170.18747@d.namei>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 14 July 2006 7:34 pm, James Morris wrote:
> On Fri, 14 Jul 2006, paul.moore@hp.com wrote:
> > +static inline void netlbl_put_hdr(unsigned char *buffer,
> > +				  const u32 msg_type,
> > +				  const u16 msg_len,
> > +				  const u16 msg_flags,
> > +				  const u32 msg_pid,
> > +				  const u32 msg_seq)
>
> Why are these parameters marked const?  Seems to be common throughout the
> code.
>

I saw similar things in the kernel, but it looks like I was looking at 
older, "less desirable"  sections of code.  Since it looks like you are still 
churning through the patchset I'll hold off on submitting a new version based 
on your comments until Monday.

Once again, thanks for your comments and patience.

-- 
paul moore
linux security @ hp
