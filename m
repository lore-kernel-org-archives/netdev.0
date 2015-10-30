From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: Re: [PATCH net 1/2] isdn_ppp: Add checks for allocation failure in isdn_ppp_open()
Date: Fri, 30 Oct 2015 09:03:45 -0400
Message-ID: <CA+5PVA50ToS+h0ahYAAN_ZG6CHnaxZjzkjKwGW=WWgzxjLT=dQ@mail.gmail.com>
References: <1444845074.31451.21.camel@decadent.org.uk>
	<20151016.004606.1112196816016985692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: isdn@linux-pingi.de, David Miller <davem@davemloft.net>,
	linux-ppp@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <20151016.004606.1112196816016985692.davem@davemloft.net>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 16, 2015 at 3:46 AM, David Miller <davem@davemloft.net> wrote:
> From: Ben Hutchings <ben@decadent.org.uk>
> Date: Wed, 14 Oct 2015 18:51:14 +0100
>
>> Compile-tested only.
>>
>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> ---
>>  drivers/isdn/i4l/isdn_ppp.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
>> index c4198fa..86f9abe 100644
>> --- a/drivers/isdn/i4l/isdn_ppp.c
>> +++ b/drivers/isdn/i4l/isdn_ppp.c
>> @@ -301,6 +301,8 @@ isdn_ppp_open(int min, struct file *file)
>>       is->compflags = 0;
>>
>>       is->reset = isdn_ppp_ccp_reset_alloc(is);
>> +     if (!is->reset)
>> +             return -ENOMEM;
>
> Ben, your email client has corrupted both of these patches.
>
> Please fix this up and resubmit, thanks.

Ben, did you resubmit these as David suggested?  I haven't found a v2 anywhere.

josh
