From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: Bad escapes in ip -online
Date: Thu, 7 Sep 2017 09:56:21 -0700
Message-ID: <20170907095621.085155ee@xeon-e3>
References: <b4972c84-c827-3a05-2267-bbcadf101260@nasa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Kodis <john.m.kodis@nasa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36675 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752271AbdIGQ43 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 12:56:29 -0400
Received: by mail-pf0-f175.google.com with SMTP id e199so397719pfh.3
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 09:56:29 -0700 (PDT)
In-Reply-To: <b4972c84-c827-3a05-2267-bbcadf101260@nasa.gov>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 7 Sep 2017 12:08:56 -0400
John Kodis <john.m.kodis@nasa.gov> wrote:

> The -online option to the 'ip link', 'ip addr', and perhaps others is 
> putting out a backslash in places where a newline character should go, 
> as so:
> 
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode 
> DEFAULT group default qlen 1000\    link/loopback 00:00:00:00:00:00 brd 
> 00:00:00:00:00:00
> 
> -- John.
> 

The backslash is the virtual line separator in the one line format.
It is has always been that way, and programs parse the oneline output.
