From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: doubt in e1000_io_write()
Date: Fri, 11 Jan 2008 10:41:37 -0800
Message-ID: <4787B861.9060203@intel.com>
References: <1200064410.1351.3.camel@vglwks010.vgl2.office.vaioni.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeba Anandhan <jeba.anandhan@vaioni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28843 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757258AbYAKSms (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jan 2008 13:42:48 -0500
In-Reply-To: <1200064410.1351.3.camel@vglwks010.vgl2.office.vaioni.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeba Anandhan wrote:
> Hi all,
> i have doubt in e1000_io_write().
> 
> void
> e1000_io_write(struct e1000_hw *hw, unsigned long port, uint32_t value)
> {
>         outl(value, port);
> }
> 
> 
> kernel version: 2.6.12.3
> 
> 
> Even hw structure has not been used, why it has been passed into
> e1000_io_write function?

2.6.12.3? why do you care? that code is probably long gone... was that function
even used?

