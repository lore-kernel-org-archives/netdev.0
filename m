From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: Fw: [Bug 107071] New: ip route add with src failes with RTNETLINK
 answers: Invalid argument
Date: Tue, 3 Nov 2015 15:21:20 -0700
Message-ID: <56393360.4090706@cumulusnetworks.com>
References: <20151103130820.3356b6cd@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f173.google.com ([209.85.214.173]:33117 "EHLO
	mail-ob0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196AbbKCWVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 17:21:24 -0500
Received: by obbwb3 with SMTP id wb3so25308521obb.0
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 14:21:23 -0800 (PST)
In-Reply-To: <20151103130820.3356b6cd@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/15 2:08 PM, Stephen Hemminger wrote:
> when I try to add sudo ip route add 10.248.5.0/24 dev bond0.250 table vlan_250
> src 10.248.5.154
>
> I get RTNETLINK answers: Invalid argument

Probably a side effect of one my patches for VRF. I'll take a look.
