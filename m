From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Lost ping responses
Date: Tue, 19 Aug 2014 07:15:00 -0400
Message-ID: <53F331B4.10802@mojatatu.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1747B1C0@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: David Laight <David.Laight@ACULAB.COM>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:52519 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752894AbaHSLPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2014 07:15:04 -0400
Received: by mail-ie0-f175.google.com with SMTP id x19so833715ier.6
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2014 04:15:02 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1747B1C0@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/14 06:28, David Laight wrote:

> Any ideas how to find out where the discards are happening?
> It might just be somewhere that would affect other traffic flows.
>

netstat -s

cat /proc/net/softnet_stat

are some points to look at.

cheers,
jamal
