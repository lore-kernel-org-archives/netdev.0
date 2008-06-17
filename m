From: Patrick McHardy <kaber@trash.net>
Subject: Re: Oops in nf_nat_core.c:find_appropriate_src(), kernel 2.6.25.4
Date: Tue, 17 Jun 2008 15:44:16 +0200
Message-ID: <4857BFB0.5080502@trash.net>
References: <484A9E75.8000601@redhat.com> <484AA276.9090407@trash.net> <484AA5D5.10404@trash.net> <Pine.LNX.4.64.0806071742180.13503@bizon.gios.gov.pl> <484E4343.5090606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Oledzki <ole@ans.pl>, Netdev <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <484E4343.5090606@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
>> On Sat, 7 Jun 2008, Patrick McHardy wrote:
>>
>>>> Chuck Ebbert wrote:
>>>>> Reported at https://bugzilla.redhat.com/show_bug.cgi?id=449315
>>>>>
>>>> We have a similar looking report, but that one also affects 2.6.24:
>>>>
>>>> http://bugzilla.kernel.org/show_bug.cgi?id=10875
> 
> We found the reason for that crash and I've queued these two
> patches. Please let me know whether they also fix the problem
> from the redhat bugzilla.


Since there doesn't seem to be any progress, I'm going to send
this upstream now so we can get some testing before 2.6.26 is
released.

I'm going to hold off sending it to -stable though until there
is confirmation that it actually fixes this problem.

