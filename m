From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -next 0/2] clsact frontend
Date: Mon, 18 Jan 2016 11:43:09 -0800
Message-ID: <20160118114309.7f67615e@xeon-e3>
References: <cover.1452558352.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35981 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756071AbcARTnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2016 14:43:03 -0500
Received: by mail-pa0-f46.google.com with SMTP id yy13so345699761pab.3
        for <netdev@vger.kernel.org>; Mon, 18 Jan 2016 11:43:02 -0800 (PST)
In-Reply-To: <cover.1452558352.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 12 Jan 2016 01:42:18 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

> Cleanup on ingress and addition of clsact frontend. There's no man-page
> for ingress nor for clsact, will follow-up with one to document both.
> 
> The patch requires a header update and is against your current net-next
> branch (pre master merge).
> 
> Thanks!
> 
> Daniel Borkmann (2):
>   tc, ingress: clean up ingress handling a bit
>   tc, clsact: add clsact frontend
> 
>  tc/Makefile    |  1 +
>  tc/q_clsact.c  | 34 ++++++++++++++++++++++++++++++++++
>  tc/q_ingress.c | 20 +++++---------------
>  tc/tc_filter.c | 46 ++++++++++++++++++++++++++++++++++++++--------
>  tc/tc_qdisc.c  | 32 ++++++++++++++++++--------------
>  5 files changed, 96 insertions(+), 37 deletions(-)
>  create mode 100644 tc/q_clsact.c
> 

Applied (to master).
