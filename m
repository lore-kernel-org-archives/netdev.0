From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] ip vrf: Add command name next to pid
Date: Fri, 14 Apr 2017 15:57:37 -0700
Message-ID: <20170414155737.24d3ce38@xeon-e3>
References: <1492048452-9052-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:32834 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752855AbdDNW5k (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Apr 2017 18:57:40 -0400
Received: by mail-pg0-f54.google.com with SMTP id x125so48359035pgb.0
        for <netdev@vger.kernel.org>; Fri, 14 Apr 2017 15:57:40 -0700 (PDT)
In-Reply-To: <1492048452-9052-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Overall, this looks like a good idea.

> +
> +int get_comm(char *pid, char *comm, int len)


Please use more glibc style function signature, like:

int get_comm(const char *pid, char *comm, size_t len)

And maybe even
int get_command_name(pid_t pid, char *comm, size_t len)
