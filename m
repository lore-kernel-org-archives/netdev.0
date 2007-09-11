From: "Felipe Balbi" <felipebalbi@users.sourceforge.net>
Subject: Re: [PATCH v2] Move the definition of pr_err() into kernel.h
Date: Tue, 11 Sep 2007 15:56:33 -0400
Message-ID: <31e679430709111256o212be3e4tcefb6decf2e136e0@mail.gmail.com>
References: <11895344211267-git-send-email-Emilian.Medve@Freescale.com>
	 <D5C1322C3E673F459512FB59E0DDC32903925779@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Emil Medve" <Emilian.Medve@freescale.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	i2c@lm-sensors.org, linux-omap-open-source@linux.omap.com
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:30489 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934136AbXIKT4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2007 15:56:35 -0400
Received: by el-out-1112.google.com with SMTP id v27so246107ele
        for <netdev@vger.kernel.org>; Tue, 11 Sep 2007 12:56:34 -0700 (PDT)
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC32903925779@orsmsx414.amr.corp.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 9/11/07, Waskiewicz Jr, Peter P <peter.p.waskiewicz.jr@intel.com> wrote:
<snip>

> > -#define pr_err(fmt, arg...)  printk(KERN_ERR DRIVER_NAME ":
> > ", ## arg);
> > -
>
> Unnecessary whitespace removal.

Actually... I prefer removing the extra blank-line... it's easier to
read and keeps on blank-line only to separate other
defines/code-portion

Same to all the others

<snip><snip><snip><snip><snip>

-- 
Best Regards,

Felipe Balbi
felipebalbi@users.sourceforge.net
