From: Thayne Harbaugh <tharbaugh@lnxi.com>
Subject: RE: [PATCH] abysmal e1000 performance (DITR)
Date: Thu, 26 Aug 2004 14:04:04 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1093550644.20769.130.camel@tubarao>
References: <468F3FDA28AA87429AD807992E22D07E014CEF36@orsmsx408>
	 <1093542930.1027.124.camel@jzny.localdomain>
Reply-To: tharbaugh@lnxi.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>, netdev@oss.sgi.com,
        "Feldman, Scott" <scott.feldman@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1093542930.1027.124.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2004-08-26 at 13:55 -0400, jamal wrote:
> Ganesh,
> 
> Can you please make this feature off by default and perhaps
> accesible via ethtool for peopel who want to turn it on.
> I just wasted a few hours and was bitten by this performance-wise.
> Please consider disabling it.

This is a *horrible* problem.  Even though it's fixable by passing a
module parameter, the default bites those that *know* about it.  We have
had customers bitten by this and customers that have insisted in
swapping all the NICs in a cluster to Broadcom TG3 NICs.

It's a black eye for Intel and a loss of business - that's the opinion
of our customers.

> cheers,
> jamal
> 
> On Fri, 2004-06-04 at 11:44, Venkatesan, Ganesh wrote:
> > Thayne:
> > 
> > We are studying the patch and will get back to you once we have a plan
> > to integrate it into the driver.
> > 
> > Thanks,
> > ganesh 
> >  
> > -------------------------------------------------
> > Ganesh Venkatesan
> > Network/Storage Division, Hillsboro, OR
> > 
> > -----Original Message-----
> > From: Thayne Harbaugh [mailto:tharbaugh@lnxi.com] 
> > Sent: Friday, June 04, 2004 7:20 AM
> > To: netdev@oss.sgi.com
> > Cc: Venkatesan, Ganesh; Feldman, Scott; Brandeburg, Jesse
> > Subject: Re: [PATCH] abysmal e1000 performance (DITR)
> > 
> > I have documented a serious performance problem with DITR in the e1000
> > driver.  I have sent a patch to the netdev list as well as CC'ed various
> > people at Intel.  There has been very little response.  I am wondering
> > who has reviewed the DITR performance problem and what the plans are for
> > fixing it.
> 
