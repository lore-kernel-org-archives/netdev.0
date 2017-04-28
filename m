From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 binutils] Add BPF support to binutils...
Date: Fri, 28 Apr 2017 13:33:57 -0400 (EDT)
Message-ID: <20170428.133357.1350487366358004505.davem@davemloft.net>
References: <f7td1bwtthr.fsf@redhat.com>
        <20170428.120457.408834081300892396.davem@davemloft.net>
        <f7tfugssblu.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56950 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1422832AbdD1ReC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 13:34:02 -0400
In-Reply-To: <f7tfugssblu.fsf@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Aaron Conole <aconole@bytheb.org>
Date: Fri, 28 Apr 2017 13:09:17 -0400

> David Miller <davem@davemloft.net> writes:
> 
>> diff --git a/bfd/elf64-bpf.c b/bfd/elf64-bpf.c
>> index 9944bb4..1be285d 100644
>> --- a/bfd/elf64-bpf.c
>> +++ b/bfd/elf64-bpf.c
>> @@ -1,8 +1,89 @@
>>  #include "sysdep.h"
>>  #include "bfd.h"
>> +#include "bfdlink.h"
>>  #include "libbfd.h"
>> +#include "libiberty.h"
>>  #include "elf-bfd.h"
>> +#include "elf/bpf.h"
>>  #include "opcode/bpf.h"
>> +#include "objalloc.h"
>> +#include "elf64-bpf.h"
> 
> I get a compile error here.  I guess this file wasn't included.

Sorry about that, here is bfd/elf64-bpf.h:

/* BPF ELF specific backend routines.
   Copyright (C) 2017 Free Software Foundation, Inc.

   This file is part of BFD, the Binary File Descriptor library.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street - Fifth Floor, Boston,
   MA 02110-1301, USA.  */

extern reloc_howto_type *_bfd_bpf_elf_reloc_type_lookup
  (bfd *, bfd_reloc_code_real_type);
extern reloc_howto_type *_bfd_bpf_elf_reloc_name_lookup
  (bfd *, const char *);
