From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 18/29] net: vrf: Plumbing for vrf context on a socket
Date: Thu, 05 Feb 2015 18:18:12 -0700
Message-ID: <54D41654.3090903@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <1423100070-31848-19-git-send-email-dsahern@gmail.com> <54D373CA.20008@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ebiederm@xmission.com
To: nicolas.dichtel@6wind.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:47178 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752364AbbBFBSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 20:18:14 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so3860637iga.0
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 17:18:13 -0800 (PST)
In-Reply-To: <54D373CA.20008@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/5/15 6:44 AM, Nicolas Dichtel wrote:
> Le 05/02/2015 02:34, David Ahern a =C3=A9crit :
>> Sockets inherit the vrf context of the task opening it. The context =
can
>> be read/changed via a socket option (IP_VRF_CONTEXT).
> What about using a common socket option (SO_VRF_CONTEXT) instead of a=
n ipv4
> specific option?

Makes sense.
