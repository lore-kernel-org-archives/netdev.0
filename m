From: Avi Kivity <avi@redhat.com>
Subject: Re: [RFC PATCH v2 00/19] virtual-bus
Date: Fri, 05 Jun 2009 15:53:31 +0300
Message-ID: <4A29154B.2000600@redhat.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <49E0C93E.5030205@redhat.com> <4A28172D.6010906@gmail.com> <200906051425.02924.rusty@rustcorp.com.au> <4A290800.1030803@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rusty Russell <rusty@rustcorp.com.au>,
	Gregory Haskins <gregory.haskins@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A290800.1030803@novell.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gregory Haskins wrote:
>> @@ -1,6 +1,6 @@
>>  config LGUEST
>>  	tristate "Linux hypervisor example code"
>> -	depends on X86_32 && EXPERIMENTAL && !X86_PAE && FUTEX
>> +	depends on X86_32 && EXPERIMENTAL && !X86_PAE && EVENTFD
>>   
>>     
>
> Note to self:  we probably need a similar line in KVM now.
>
>   

'select EVENTFD' is more appropriate.


-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.

