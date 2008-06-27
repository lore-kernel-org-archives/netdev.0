From: "Joonwoo Park" <joonwpark81@gmail.com>
Subject: Re: [PATCH 6/8 v2] netfilter: fix string extension for case insensitive pattern matching
Date: Fri, 27 Jun 2008 02:49:34 -0700
Message-ID: <b25c3fa70806270249m2a6e8962r6e8e1fd3c18d82a0@mail.gmail.com>
References: <1214389505-21405-1-git-send-email-joonwpark81@gmail.com>
	 <4862260A.9060304@trash.net> <20080626021241.GA26212@tp64>
	 <48637EBA.6080003@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	"Thomas Graf" <tgraf@suug.ch>,
	"Pablo Neira Ayuso" <pablo@netfilter.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48637EBA.6080003@trash.net>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2008/6/26 Patrick McHardy <kaber@trash.net>:
> Joonwoo Park wrote:
>>
>> netfilter: fix string extension for case insensitive pattern matching
>>
>> The flag XT_STRING_FLAG_IGNORECASE indicates case insensitive string
>> matching.
>> netfilter can find cmd.exe, Cmd.exe, cMd.exe and etc easily.
>>
>> Also this patch won't break compatibility since we have 2 bytes space
>> between invert and config, due to config was 8 bytes aligned.
>> So we can put a new value 'flags' in xt_string_info between invert and
>> config safely.
>> If previous version of iptables interact with this kernel, to kernel
>> side, flags will be set to zero and to user side, flags will be ignored.
>
> This makes it hard for userspace to know whether insensitive
> search is supported or not, similar for possible future flag
> additions.
>
> Please
>
> - add a new revision for userspace to know whether flags are
>  supported at all. You don't need to duplicate the checkentry
>  function for this since the structure layout didn't change,
>  you can simply parse flags dependant on match->revision.
>  Userspace can use the existance of the new revision as
>  indication that flags are supported.
>
> - check for unknown flags and return an error
>

Hi Patrick,
Thanks for your advice.
Since I'm traveling America, so maybe I could catch up these things
you've asked next weekend.
I don't need to rush, do I?

Thanks again,
Joonwoo
