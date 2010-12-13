From: Jesse Gross <jesse@nicira.com>
Subject: Re: set vlan CFI and TPID
Date: Sun, 12 Dec 2010 16:20:58 -0800
Message-ID: <AANLkTim3Rm91O2n6dCqTJYja8fy_sb0dKthCA1rf=FPV@mail.gmail.com>
References: <AANLkTimW35xF4dcr_UO6XX1tBb3VBcp2PWPq8SkMk60=@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: hong zhiyi <zhiyi.hong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:64108 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab0LMAU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Dec 2010 19:20:59 -0500
Received: by fxm18 with SMTP id 18so5708401fxm.2
        for <netdev@vger.kernel.org>; Sun, 12 Dec 2010 16:20:58 -0800 (PST)
In-Reply-To: <AANLkTimW35xF4dcr_UO6XX1tBb3VBcp2PWPq8SkMk60=@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 7, 2010 at 8:04 PM, hong zhiyi <zhiyi.hong@gmail.com> wrote:
> Hi All,
>
> May I ask how to set the 1 bit CFI and 2 bytesTPID in the VLAN header
> by vconfig?

You can't change them using vconfig.  For 802.1q/Ethernet, the TPID is
0x8100 and the CFI is 0.

> and what is the meaning of the egress map and ingress map?

These convert between the PCP bits found in the vlan header and the
priority field that is used internally for QoS, which you access
through tc.
