From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Fri, 23 Jan 2015 11:47:08 -0700
Message-ID: <54C2972C.3080702@gmail.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com> <20150122224033.6e2db5ce@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@redhat.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:56940 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756292AbbAWSrO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 13:47:14 -0500
Received: by mail-pa0-f41.google.com with SMTP id kq14so7614213pab.0
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 10:47:14 -0800 (PST)
In-Reply-To: <20150122224033.6e2db5ce@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/15 11:40 PM, Stephen Hemminger wrote:
> Would this break existing application expecting a particular semantic
> by listening to netlink?  What happens to packets received with the static
> address when interface is down? With IPv4 Linux is mostly a weak host
> model, and IPv6 somewhere in between.
>
> For vendors that control the application stack or have limited number
> of services this would work fine, but what about RHEL?
>
>

The intent of making it a sysctl option is to maintain backwards 
compatibility and allow users to take the new functionality if desired - 
which includes accepting changes in behavior.

David
