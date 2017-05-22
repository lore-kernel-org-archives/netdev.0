From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] include stdint.h explicitly for UINT16_MAX)
Date: Mon, 22 May 2017 11:44:53 -0700
Message-ID: <20170522114453.2de34178@xeon-e3>
References: <20170520212846.3534-1-raj.khem@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Khem Raj <raj.khem@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34185 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760756AbdEVSpB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:45:01 -0400
Received: by mail-pf0-f175.google.com with SMTP id 9so90323142pfj.1
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:45:01 -0700 (PDT)
In-Reply-To: <20170520212846.3534-1-raj.khem@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 May 2017 14:28:46 -0700
Khem Raj <raj.khem@gmail.com> wrote:

> Fixes
> | tc_core.c:190:29: error: 'UINT16_MAX' undeclared (first use in this function); did you mean '__INT16_MAX__'?
> |    if ((sz >> s->size_log) > UINT16_MAX) {
> |                              ^~~~~~~~~~
> 
> Signed-off-by: Khem Raj <raj.khem@gmail.com>

Applied.
