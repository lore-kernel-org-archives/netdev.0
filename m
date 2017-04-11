From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bpf: add test_progs to .gitignore
Date: Tue, 11 Apr 2017 08:08:24 -0600
Message-ID: <6cea626b-d95d-743b-2f3e-d64e65d9df88@cumulusnetworks.com>
References: <20170411113538.31423-1-alexander@alemayhu.com>
 <58ECC2B6.1020104@iogearbox.net> <20170411121427.GB5207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com
To: Alexander Alemayhu <alexander@alemayhu.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:32897 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753101AbdDKOI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 10:08:26 -0400
Received: by mail-oi0-f45.google.com with SMTP id b187so184516571oif.0
        for <netdev@vger.kernel.org>; Tue, 11 Apr 2017 07:08:25 -0700 (PDT)
In-Reply-To: <20170411121427.GB5207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/11/17 6:14 AM, Alexander Alemayhu wrote:
> On Tue, Apr 11, 2017 at 01:49:10PM +0200, Daniel Borkmann wrote:
>>
>> Good point, we should also add '*.o' in that case for the
>> TEST_GEN_FILES specified objs that clang generates.
> 
> Think that is covered by other files but added. Would it be
> okay to ignore all the generated files, like the below?

listing each program is not a sustainable way to do this. It would be
simpler to put build targets into a build directory and then ignore the
build directory.
