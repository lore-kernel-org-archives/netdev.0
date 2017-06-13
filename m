From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH] Add printk for bonding module packets_per_slave parameter
Date: Tue, 13 Jun 2017 20:53:40 +0300
Message-ID: <1e319c81-0a39-0b1e-75ff-96eb7a5963df@cumulusnetworks.com>
References: <20170613134246.6407-1-michael.j.dilmore@gmail.com>
 <20170613.113411.506760268959654820.davem@davemloft.net>
 <1497370863.18751.15.camel@perches.com>
 <dffd68fa-66bf-7709-7df7-7aa5e0e2ed44@redhat.com>
 <1497373252.18751.19.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>, jtoppins@redhat.com,
        David Miller <davem@davemloft.net>, michael.j.dilmore@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497373252.18751.19.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 13/06/17 20:00, Joe Perches wrote:
> On Tue, 2017-06-13 at 12:42 -0400, Jonathan Toppins wrote:
>> On 06/13/2017 12:21 PM, Joe Perches wrote:
>>> On Tue, 2017-06-13 at 11:34 -0400, David Miller wrote:
>>>> From: Michael Dilmore <michael.j.dilmore@gmail.com>
>>>> Date: Tue, 13 Jun 2017 14:42:46 +0100
>>>>
>>>>> The packets per slave parameter used by round robin mode does not have a printk debug
>>>>> message in its set function in bond_options.c. Adding such a function would aid debugging
>>>>> of round-robin mode and allow the user to more easily verify that the parameter has been
>>>>> set correctly. I should add that I'm motivated by my own experience here - it's not
>>>>> obvious from output of tools such as wireshark and ifstat that the parameter is working
>>>>> correctly, and with the differences in bonding configuration across different distributions,
>>>>> it would have been comforting to see this output.
> []
>>>> You can verify things by simplying reading the value back.
>>>>
>>>> If every parameter emitted a kernel log message, it would be
>>>> unreadable.
>>>>
>>>> I'm not applying this, sorry.
>>>
>>> I agree.  Noisy logging output is not good.
>>>
>>> Perhaps a general conversion of the dozens
>>> of existing netdev_info uses in this file to
>>> netdev_dbg and adding this at netdev_dbg is
>>> appropriate.
>>
>> In general I agree. The few times I have debugged bonds, I always ended
>> up enabling debug prinks anyway. I don't see a problem moving these to
>> debug as well.
>>
>> Adding nik whom converted a lot of this code to common paths for input.
> 
> If Nikolay agrees with the conversion, it's trivial.
> Please submit it.  I did it just for reference.
> 
> Stylistic nits about the existing file:
> 
> There are some inconsistencies in pr_info/pr_err uses
> with invalid inputs.
> 
> It would also be nicer if the forward static declarations
> were removed and the static definitions reordered.
> 

Agreed, there are many ways to extract the values.
