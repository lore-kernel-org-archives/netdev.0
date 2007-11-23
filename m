From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][UNIX] Move the unix sock iterators in to proper place
Date: Fri, 23 Nov 2007 16:10:08 +0300
Message-ID: <4746D130.2060305@openvz.org>
References: <47458296.60908@openvz.org> <20071123123036.GD18862@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:47001 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756145AbXKWNKZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 08:10:25 -0500
In-Reply-To: <20071123123036.GD18862@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Thu, Nov 22, 2007 at 04:22:30PM +0300, Pavel Emelyanov wrote:
>> The first_unix_socket() and next_unix_sockets() are now used
>> in proc file and in forall_unix_socets macro only.
>>
>> The forall_unix_sockets is not used in this file at all so
>> remove it. After this move the helpers to where they really 
>> belong, i.e. closer to proc code under the #ifdef CONFIG_PROC_FS
>> option.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Patch applied.  Thanks Pavel!

I'm afraid to become importunate, but is the net-2.6 (not 25)
tree is currently the David's tree (unlike net-2.6.25, which
has temporary switched to your one)?

Thanks,
Pavel
