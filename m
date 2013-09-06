From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs
 interfaces
Date: Fri, 6 Sep 2013 03:09:35 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E416C6251E3@FMSMSX102.amr.corp.intel.com>
References: <FC41C24E35F18A40888AACA1A36F3E416C61CF23@FMSMSX102.amr.corp.intel.com>
	<20130904.231950.956676623509287249.davem@davemloft.net>
	<1378354121.26131.4.camel@jbrandeb-mobl2>
 <20130905.003757.50136071703836331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: David Miller <davem@davemloft.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:6560 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753734Ab3IFDJh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 23:09:37 -0400
In-Reply-To: <20130905.003757.50136071703836331.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Wednesday, September 04, 2013 9:38 PM
> To: Brandeburg, Jesse
> Cc: Nelson, Shannon; stephen@networkplumber.org; Kirsher, Jeffrey T;
> e1000-devel@lists.sourceforge.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [E1000-devel] [net-next v4 7/8] i40e: sysfs and debugfs
> interfaces
> 
> From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
> Date: Thu, 5 Sep 2013 04:08:39 +0000
> 
> > On Wed, 2013-09-04 at 23:19 -0400, David Miller wrote:
> >> You will fix the problems people are reporting with this patch series
> >> before I apply it.
> >
> > Okay, the quickest path to that might be to drop the sysfs patch for
> > now.  If that is acceptable I will re-spin the patches tonight.
> 
> You're just going to ask me to add the sysfs code later, just make
> the appropriate fixes.
> 
> Thanks.

After some discussion with Stephen and a few others internally, it doesn't look like there's any easy resolution to the i40e sysfs problems so for now we're going to leave that module out of our submission.  Yes, we may want to bring it back in the future, but not until we've had a chance to work through the fundamental problems and come up with an interface that will be more generic, usable, and acceptable by other similar drivers.

Thanks,
sln
