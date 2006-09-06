From: Kirill Korotaev <dev@sw.ru>
Subject: Re: [RFC] network namespaces
Date: Wed, 06 Sep 2006 18:52:50 +0400
Message-ID: <44FEE0C2.6020205@sw.ru>
References: <20060815182029.A1685@castle.nmd.msu.ru>	<20060816115313.GC31810@sergelap.austin.ibm.com>	<44FD7CF0.4030009@fr.ibm.com>	<m1ejuq2wz0.fsf@ebiederm.dsl.xmission.com>	<20060905165328.GA17317@MAIL.13thfloor.at> <m17j0i1853.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Herbert Poetzl <herbert@13thfloor.at>,
	Andrey Savochkin <saw@sw.ru>, netdev@vger.kernel.org,
	Linux Containers <containers@lists.osdl.org>, alexey@sw.ru,
	sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:36775 "EHLO relay.sw.ru")
	by vger.kernel.org with ESMTP id S1751198AbWIFOt7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 10:49:59 -0400
To: "Eric W. Biederman" <ebiederm@xmission.com>
In-Reply-To: <m17j0i1853.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>On Tue, Sep 05, 2006 at 08:45:39AM -0600, Eric W. Biederman wrote:
>>
>>>Daniel Lezcano <dlezcano@fr.ibm.com> writes:
>>>
>>>For HPC if you are interested in migration you need a separate IP
>>>per container. If you can take you IP address with you migration of
>>>networking state is simple. If you can't take your IP address with you
>>>a network container is nearly pointless from a migration perspective.
>>>
>>>Beyond that from everything I have seen layer 2 is just much cleaner
>>>than any layer 3 approach short of Serge's bind filtering.
>>
>>well, the 'ip subset' approach Linux-VServer and
>>other Jail solutions use is very clean, it just does
>>not match your expectations of a virtual interface
>>(as there is none) and it does not cope well with
>>all kinds of per context 'requirements', which IMHO
>>do not really exist on the application layer (only
>>on the whole system layer)
> 
> 
> I probably expressed that wrong.  There are currently three
> basic approaches under discussion.
> Layer 3 (Basically bind filtering) nothing at the packet level.
>    The approach taken by Serge's version of bsdjails and Vserver.
> 
> Layer 2.5 What Daniel proposed.
> 
> Layer 2.  (Trivially mapping each packet to a different interface)
>            And then treating everything as multiple instances of the
>            network stack.
>         Roughly what OpenVZ and I have implemented.
I think classifying network virtualization by Layer X is not good enough.
OpenVZ has Layer 3 (venet) and Layer 2 (veth) implementations, but
in both cases networking stack inside VE remains fully virtualized.

Thanks,
Kirill

