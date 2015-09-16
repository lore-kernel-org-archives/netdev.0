From: Damian Hobson-Garcia <dhobsong@igel.co.jp>
Subject: Re: [PATCH v2 1/1] eventfd: implementation of EFD_MASK flag
Date: Wed, 16 Sep 2015 16:43:58 +0900
Message-ID: <55F91DBE.90903@igel.co.jp>
References: <1442384836-13045-1-git-send-email-dhobsong@igel.co.jp>
 <1442384836-13045-2-git-send-email-dhobsong@igel.co.jp>
 <70093385dc00b108e16862c8b8b1c13c@imap.lucina.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: viro@zeniv.linux.org.uk, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, David.Laight@aculab.com
To: Martin Sustrik <sustrik@250bpm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <70093385dc00b108e16862c8b8b1c13c@imap.lucina.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Martin,

On 2015-09-16 3:51 PM, Martin Sustrik wrote:
> On 2015-09-16 08:27, Damian Hobson-Garcia wrote:
>>
>> Additionally, to provide a way to associate user-space state with eventfd
>> object, it allows to attach user-space data to the file descriptor.
> 
> The above paragraph is a leftover from the past. The functionality no
> longer exist.
> 
Oops, I forgot to delete that part. I'll get rid of it.

>>
>> The semantics of EFD_MASK are as follows:
>>
>> eventfd(2):
>>
>> If eventfd is created with EFD_MASK flag set, it is initialised in such a
>> way as to signal no events on the file descriptor when it is polled on.
>> The 'initval' argument is ignored.
>>
>> write(2):
>>
>> User is allowed to write only buffers containing the following structure:
>>
>> struct efd_mask {
>>   uint32_t events;
>> };
> 
> Is it worth having a struct here? Why not just uint32_t?
As it stands right now, no, the struct doesn't really add anything.
uint32_t should be just fine.
> 
> Martin

Damian
