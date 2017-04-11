From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bpf: add test_progs to .gitignore
Date: Tue, 11 Apr 2017 09:16:52 -0600
Message-ID: <7c88049b-ecac-9860-0d6b-9635b9d93c4f@cumulusnetworks.com>
References: <20170411113538.31423-1-alexander@alemayhu.com>
 <58ECC2B6.1020104@iogearbox.net> <20170411121427.GB5207@gmail.com>
 <6cea626b-d95d-743b-2f3e-d64e65d9df88@cumulusnetworks.com>
 <20170411144308.GA3700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        ast@fb.com
To: Alexander Alemayhu <alexander@alemayhu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33968 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752506AbdDKPRA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 11:17:00 -0400
Received: by mail-pg0-f53.google.com with SMTP id 21so127176pgg.1
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 08:16:59 -0700 (PDT)
In-Reply-To: <20170411144308.GA3700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/11/17 8:43 AM, Alexander Alemayhu wrote:
> On Tue, Apr 11, 2017 at 08:08:24AM -0600, David Ahern wrote:
>> listing each program is not a sustainable way to do this. It would be
>> simpler to put build targets into a build directory and then ignore the
>> build directory.
> Agreed. It has probably been raised before, but if no one else does I can send
> something later (still learning the make syntax).

Getting samples/bpf to honor the O= setting is needed as well.
