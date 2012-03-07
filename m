From: deepaksi <deepak.sikri@st.com>
Subject: Re: [PATCH 1/6] stmmac: Define CSUM offload engine Types
Date: Wed, 7 Mar 2012 12:20:56 +0530
Message-ID: <4F570550.6010404@st.com>
References: <1330692928-30330-1-git-send-email-deepak.sikri@st.com> <1330692928-30330-2-git-send-email-deepak.sikri@st.com> <4F54CA08.7050207@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: spear-devel <spear-devel@list.st.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:58162 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750747Ab2CGGvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 01:51:32 -0500
Received: from zeta.dmz-ap.st.com (ns6.st.com [138.198.234.13])
	by beta.dmz-ap.st.com (STMicroelectronics) with ESMTP id D0284E5
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 06:43:01 +0000 (GMT)
Received: from Webmail-ap.st.com (eapex1hubcas4.st.com [10.80.176.69])
	by zeta.dmz-ap.st.com (STMicroelectronics) with ESMTP id A9BB910E6
	for <netdev@vger.kernel.org>; Wed,  7 Mar 2012 06:51:26 +0000 (GMT)
In-Reply-To: <4F54CA08.7050207@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Peppe,

> this patch is useful but I've some notes.
>
> Pay attention that, new GMAC devices have the HW capability register to
> understand if the rx_coe_type is TYPE1 or TYPE2.
> These values should always override the ones come from the platform.
> This check is missing in your code.
> Can I ask you to rename csum_off_engine_type as rx_coe_type to be
> aligned to the name convention used inside the driver.
>
> Regards
> Peppe

Will change the naming convention in this file as well as driver.

Regards
Deepak
