From: Shuah Khan <shuah@kernel.org>
Subject: Re: [PATCH v3 net-next 1/2] tools: psock_lib: tighten conditions
 checked in sock_setfilter
Date: Wed, 4 Jan 2017 16:26:29 -0700
Message-ID: <3be167c0-b7cb-1ab4-6afe-e2e84a3404f5@kernel.org>
References: <cover.1483555162.git.sowmini.varadhan@oracle.com>
 <3aa068fa482f7cf5381957e9a3ea58550822d1d1.1483555162.git.sowmini.varadhan@oracle.com>
 <d3e75147-475a-823c-3530-5150dd24a63d@kernel.org>
 <20170104225554.GD31756@oracle.com>
Reply-To: shuah@kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: linux-kselftest@vger.kernel.org, netdev@vger.kernel.org,
        daniel@iogearbox.net, willemb@google.com, davem@davemloft.net,
        Shuah Khan <shuah@kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-po-08v.sys.comcast.net ([96.114.154.167]:56487 "EHLO
        resqmta-po-08v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1761755AbdADX2c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 18:28:32 -0500
In-Reply-To: <20170104225554.GD31756@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2017 03:55 PM, Sowmini Varadhan wrote:
> On (01/04/17 15:37), Shuah Khan wrote:
>>> +	/* the filter below checks for all of the following conditions that
>>> +	 * are based on the contents of create_payload()
>>> +	 *  ether type 0x800 and
>>> +	 *  ip proto udp     and
>>> +	 *  ip len == ip_len and
>>> +	 *  udp[38] == 'a' or udp[38] == 'b'
>>> +	 */
>>
>> Looks like you have to do v4 anyway, please make sure your comment
>> block is one of the acceptable formats based on coding style:
>>
>> https://marc.info/?l=linux-crypto-vger&m=146799837129319&w=2
> 
> BTW, the above is conformant with the comment style required for
> networking:
> 
> https://www.kernel.org/doc/Documentation/networking/netdev-FAQ.txt
> 
> which seems to be used in psock_fanout.c and reuseport_bpf.c as well.

I would like to see the comment blocks in selftest consistent with the
Kernel coding style.

> 
> Thanks
> --Sowmini
> 

Could you please split this patch into two. Hardening part in one and
the cleanup in a separate patch. This way I can get the hardening fix
into 4.10 in my next Kselftest update. Cleanup patch can go in later.

thanks,
-- Shuah
