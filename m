From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Network driver questions
Date: Tue, 29 Apr 2008 14:42:28 +0100
Message-ID: <20080429134226.GI8986@solarflare.com>
References: <17896ec80804290540s492962a6ke0ab8790755337de@mail.gmail.com> <17896ec80804290621w1b4573c4lc0fa7eaec4f6c7dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mile Davidovic <md4linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:34082 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755278AbYD2Nmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2008 09:42:35 -0400
Content-Disposition: inline
In-Reply-To: <17896ec80804290621w1b4573c4lc0fa7eaec4f6c7dd@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mile Davidovic wrote:
> Hello,
> We have some dedicated interface for connecting various external
> devices (NOR, ONENAND, SMSC network adapter), similar to PCI except
> one big difference/restriction:
> 
> we can not work in atomic context because low lever drivers have such
> limitation.
> 
> I would like to write network driver (for SMSC chip for example) with
> this restriction.
> 
> Do we have some network driver which also have suffer from similar restrictions?

USB network drivers are probably dealing with similar restrictions
(no synchronous access to device registers).

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
