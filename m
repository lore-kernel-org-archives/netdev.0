From: Dmitry Torokhov <dtor@vmware.com>
Subject: Re: [Pv-drivers] RFC: Network Plugin Architecture (NPA) for vmxnet3
Date: Wed, 5 May 2010 10:35:28 -0700
Message-ID: <201005051035.29831.dtor@vmware.com>
References: <20100504230225.GP8323@vmware.com> <201005051029.42052.dtor@vmware.com> <20100505173120.GA1752@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "pv-drivers@vmware.com" <pv-drivers@vmware.com>,
	Pankaj Thakkar <pthakkar@vmware.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([65.115.85.73]:43175 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753500Ab0EERfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 13:35:31 -0400
In-Reply-To: <20100505173120.GA1752@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 05 May 2010 10:31:20 am Christoph Hellwig wrote:
> On Wed, May 05, 2010 at 10:29:40AM -0700, Dmitry Torokhov wrote:
> > > We're not going to add any kind of loader for binry blobs into kernel
> > > space, sorry.  Don't even bother wasting your time on this.
> > 
> > It would not be a binary blob but software properly released under GPL.
> > The current plan is for the shell to enforce GPL requirement on the
> > plugin code, similar to what module loaded does for regular kernel
> > modules.
> 
> The mechanism described in the document is loading a binary blob
> coded to an abstract API.

Yes, with the exception that the only body of code that will be
accepted by the shell should be GPL-licensed and thus open and available
for examining. This is not different from having a standard kernel
module that is loaded normally and plugs into a certain subsystem.
The difference is that the binary resides not on guest filesystem
but elsewhere.

> 
> That's something entirely different from having normal modules for
> the Virtual Functions, which we already have for various pieces of
> hardware anyway.

-- 
Dmitry
