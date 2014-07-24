From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 14/14] i40e: always print aqtx answer
Date: Thu, 24 Jul 2014 12:56:01 -0700
Message-ID: <1406231761.27221.65.camel@joe-AO725>
References: <1406207604-31653-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1406207604-31653-15-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1406227350.27221.63.camel@joe-AO725>
	 <FC41C24E35F18A40888AACA1A36F3E418ACFCB94@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0226.hostedemail.com ([216.40.44.226]:47448 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S934176AbaGXT4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 15:56:05 -0400
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418ACFCB94@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-24 at 19:20 +0000, Nelson, Shannon wrote:
> > From: Joe Perches [mailto:joe@perches.com]
> > Sent: Thursday, July 24, 2014 11:43 AM
> > 
> > On Thu, 2014-07-24 at 06:13 -0700, Jeff Kirsher wrote:
> > > From: Shannon Nelson <shannon.nelson@intel.com>
> > >
> > > Sometimes the AQTX answer comes back with no data, but we still want
> > to print
> > > the descriptor that got written back.
> > 
> > Maybe this does some reads from buffer beyond its size
> > in i40e_debug_aq?  Is that always safe?
> 
> This is safe because we'll only print the descriptor in this case, not the buffer.  There's a check in i40e_debug_aq() for NULL or zero-length buffer.

The question is not for descriptor length 0 or null,
but bad descriptor length.
