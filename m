From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: inet_diag insufficient validation?
Date: Wed, 01 Jun 2011 11:50:18 -0400
Message-ID: <1306943418.3150.12.camel@dan>
References: <1306942849.3150.10.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, netdev@vger.kernel.org, security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:56460 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab1FAPu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 11:50:27 -0400
In-Reply-To: <1306942849.3150.10.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-06-01 at 11:40 -0400, Dan Rosenberg wrote:

> Once the bytecode is actually run in inet_diag_bc_run(), it looks like
> more infinite loops are possible, if appropriate "yes" or "no" values
> are set to zero and weren't validated by the audit.

On second glance, there don't appear to be any infinite loops at runtime
(but the audit loop seems real).  Thanks to Nelson Elhage for setting me
straight.

-Dan

