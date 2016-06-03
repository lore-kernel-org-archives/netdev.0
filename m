From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH] soreuseport: add compat case for setsockopt SO_ATTACH_REUSEPORT_CBPF
Date: Fri, 3 Jun 2016 17:33:09 -0400
Message-ID: <CAEfhGiwwvwf31Dj+s0zA0bpVAZ4x4=rLuU5g217u=wRrgm07Dg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Alexei Starovoitov <ast@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-parisc@vger.kernel.org" <linux-parisc@vger.kernel.org>
To: Helge Deller <deller@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34615 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbcFCVdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 17:33:12 -0400
Received: by mail-lf0-f44.google.com with SMTP id k98so62417988lfi.1
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:33:12 -0700 (PDT)
Received: from mail-lf0-f52.google.com (mail-lf0-f52.google.com. [209.85.215.52])
        by smtp.gmail.com with ESMTPSA id f93sm547458lji.46.2016.06.03.14.33.10
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Jun 2016 14:33:10 -0700 (PDT)
Received: by mail-lf0-f52.google.com with SMTP id s64so62426747lfe.0
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 14:33:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 3, 2016 at 5:09 PM, Helge Deller <deller@gmx.de> wrote:
> Any idea for a better naming than "do_sockopt_fix_sock_fprog()" ?
Thanks for catching and fixing this.  I'd suggest simply leaving the
function name as-is.  Your fix to the condition in that function is
sufficient to address the issue.

Craig
