From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] net: filter: Convert the BPF VM to threaded code
Date: Mon, 1 Aug 2011 20:16:52 +0200
Message-ID: <20110801181652.GB2732@nuttenaction>
References: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Rui Ueyama <rui314@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:35054 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752426Ab1HASQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Aug 2011 14:16:56 -0400
Content-Disposition: inline
In-Reply-To: <CACKH++ZfNTB7Y8YhvQnZPEXpwmpWXzxQgnWniamDrjRWUwxaNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Rui Ueyama | 2011-07-29 01:10:26 [-0700]:

>Convert the BPF VM to threaded code to improve performance.
>
>The BPF VM is basically a big for loop containing a switch statement.  That is
>slow because for each instruction it checks the for loop condition and does the
>conditional branch of the switch statement.
>
>This patch eliminates the conditional branch, by replacing it with jump table
>using GCC's labels-as-values feature. The for loop condition check can also be
>removed, because the filter code always end with a RET instruction.

With commit 01f2f3f6ef4d076c I reworked the BPF code so that gcc is in the
ability to generate a jump table, I double checked this. Not sure what happened
in the meantime.

Hagen


