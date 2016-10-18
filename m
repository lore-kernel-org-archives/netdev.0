From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH 1/8] tools lib bpf: add error functions
Date: Tue, 18 Oct 2016 15:52:18 -0700
Message-ID: <CAPWQB7Fvz=MkHGRVPR924BXzuWuLn6VTqaNGR+x_TYhycdOLag@mail.gmail.com>
References: <20161016211834.11732-1-eric@regit.org> <20161016211834.11732-2-eric@regit.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>, wangnan0@huawei.com,
        linux-kernel@vger.kernel.org, ast@fb.com
To: Eric Leblond <eric@regit.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:38844 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756340AbcJRW5d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 18:57:33 -0400
In-Reply-To: <20161016211834.11732-2-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16 October 2016 at 14:18, Eric Leblond <eric@regit.org> wrote:
> The include of err.h is not explicitely needed in exported
> functions and it was causing include conflict with some existing
> code due to redefining some macros.
>
> To fix this, let's have error handling functions provided by the
> library. Furthermore this will allow user to have an homogeneous
> API.
>
> Signed-off-by: Eric Leblond <eric@regit.org>

Does it need to return the error like this or should we just fix up
the bpf_object__open() API to return errors in a simpler form?

There's already libbpf_set_print(...) for outputting errors, is it
reasonable to just change the library to return NULLs in error cases
instead?
