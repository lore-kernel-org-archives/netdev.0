From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: headsup: llvm now uses official bpf e_machine value
Date: Fri, 15 Jul 2016 16:08:31 -0700
Message-ID: <CAADnVQ+nuswu1kC2ae_4-pZve-u1tL5JsOx1e2QbTO4ozyOh7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	iovisor-dev <iovisor-dev@lists.iovisor.org>,
	Wang Nan <wangnan0@huawei.com>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	Richard Henderson <rth@twiddle.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Brenden Blanco <bblanco@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:33119 "EHLO
	mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751388AbcGOXIx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jul 2016 19:08:53 -0400
Received: by mail-lf0-f67.google.com with SMTP id f93so7814679lfi.0
        for <netdev@vger.kernel.org>; Fri, 15 Jul 2016 16:08:52 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

just pushed Richard's patch
https://github.com/llvm-mirror/llvm/commit/36b9c09330bfb5e771914cfe307588f30d5510d2

tested with bcc and different bpf loaders.
Thankfully none of them rely on old and arguably
buggy em_none value, so no breakage expected.
if you're using special bpf elf loader, please test.

Thanks
