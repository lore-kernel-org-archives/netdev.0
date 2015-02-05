From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [RFC PATCH 18/29] net: vrf: Plumbing for vrf context on a socket
Date: Thu, 05 Feb 2015 14:44:42 +0100
Message-ID: <54D373CA.20008@6wind.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-19-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f170.google.com ([74.125.82.170]:56364 "EHLO
	mail-we0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752640AbbBENoo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:44:44 -0500
Received: by mail-we0-f170.google.com with SMTP id w55so7777003wes.1
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:44:43 -0800 (PST)
In-Reply-To: <1423100070-31848-19-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
> Sockets inherit the vrf context of the task opening it. The context c=
an
> be read/changed via a socket option (IP_VRF_CONTEXT).
What about using a common socket option (SO_VRF_CONTEXT) instead of an =
ipv4
specific option?
