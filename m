From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH 1/4] Prefix List against 2.5.73
Date: Tue, 15 Jul 2003 17:20:30 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307151320.RAA08283@dub.inr.ac.ru>
References: <20030715.155930.65250697.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar@us.ibm.com, davem@redhat.com, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20030715.155930.65250697.yoshfuji@linux-ipv6.org> from "YOSHIFUJIHideaki/=?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at éÀÌ 15, 2003 03:59:30 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> > > +	IFA_IFFLAGS,
> > 
> > What's about ifa_flags? There is some space there, and the things
> > kept there now: TENTATIVE/DEPRECATED et al. are close relatives
> > of O/M.
> 
> Alexey, O/M are not flags for addresses, but for interfaces.
> I believe we should not mix them up.

OK.

But tell me, please, what is the difference between new _address_
attribute IFA_IFFLAGS and already existing address attrbute ifa_flags?
If you are going to enclose these per-interface flags to address information,
they can be enclosed within existing attrubute.

Alexey
