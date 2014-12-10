From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] lib names: Refactoring and cleanups
Date: Tue, 9 Dec 2014 20:38:56 -0800
Message-ID: <20141209203856.491322c0@urahara>
References: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Vadim Kochan <vadim4j@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:49262 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755265AbaLJEjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 23:39:05 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so1955488pdb.8
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2014 20:39:05 -0800 (PST)
In-Reply-To: <1417831512-19452-1-git-send-email-vadim4j@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat,  6 Dec 2014 04:05:10 +0200
Vadim Kochan <vadim4j@gmail.com> wrote:

> Some cleanups and refactoring in lib/rt_names.c:
> 
>     #1 Replaced using of /etc/iproute2 path by CONFDIR define
>         when initializing tables of group names.
> 
>     #2 Added helper to have one func for parsing id and names from
>         db files.
> 
> Vadim Kochan (2):
>   lib names: Use CONFDIR for specify 'group' file path
>   lib names: Add helper func for parse id and name from file
> 
>  lib/rt_names.c | 70 +++++++++++++++++++++++++++++++++-------------------------
>  1 file changed, 40 insertions(+), 30 deletions(-)
> 

Both applied
