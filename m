From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [patch -mm] net namespace: empty framework
Date: Wed, 22 Nov 2006 17:57:52 +0100
Message-ID: <45648190.20000@fr.ibm.com>
References: <4563007B.9010202@fr.ibm.com> <4563046B.6040909@sw.ru>	<45633EDF.3050309@fr.ibm.com> <200611221121.59322.dim@openvz.org>	<4564566F.7030202@fr.ibm.com> <20061122164154.GB17378@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Dmitry Mishin <dim@openvz.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Kirill Korotaev <dev@sw.ru>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Herbert Poetzl <herbert@13thfloor.at>,
	"Eric W. Biederman" <ebiederm@xmission.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:59023 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1755902AbWKVQ56
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Nov 2006 11:57:58 -0500
To: "Serge E. Hallyn" <serue@us.ibm.com>
In-Reply-To: <20061122164154.GB17378@sergelap.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> Where is Andrey's patch?

The last I saw was on 2.6.18-rc4-mm1 : 

http://marc.theaimsgroup.com/?l=linux-netdev&m=115572448503723&w=2

>> the spirit of uts and ipc namespace (and user namespace if that reaches the
>> kernel one day :) so that's why i made the small changes.
> 
> I agree the namespace frameworks should be consistent, but i don't know
> whether Andrey's is or not.  I'd like to have the framework included so
> we reduce the number of silly rewrites due to clone flag collisions etc.

yes. it is a pain to maintain.

>> It also helping the nsproxy/namespace syscalls to have a similar interface
>> to manipulate namespaces. who knows, soon we might be able to have a 'struct
>> namespace' with a ops field to define new namespace types ?
>>
>> I can also send a empty framework for user namespace  ;)
> 
> Please do - then I'll rebase the patchset I sent to the containes list
> onto your patch, and resubmit the whole userns.

I'll send a refreshed version of both in the next round.

C.

