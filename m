From: nick <yocto6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] wireless: Remove unnessary write over of
 register 11 in rt2800lib.c
Date: Sun, 28 Sep 2014 08:34:40 -0400
Message-ID: <54280060.60706@gmail.com>
References: <1411852301-26857-1-git-send-email-yocto6@gmail.com>	<20140928070923.GA2087@redhat.com>
	<CAOJe8K1nkeVjNpNoUBxuJv-YXj3Wr_oH86yR31U7w3Jq5j7oxw@mail.gmail.com>
	<5427FE15.7080100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Denis Kirjanov <kda-u1c8ncikuMvVAZt0uhVF+Ni2O/JbrIOy@public.gmane.org>,
	Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
In-Reply-To: <5427FE15.7080100-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com/>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: "users" <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Id: netdev.vger.kernel.org



On 14-09-28 08:24 AM, nick wrote:
> 
> 
> On 14-09-28 04:05 AM, Denis Kirjanov wrote:
>> Or someone with the hardware has to test and check that...
>>
>> On 9/28/14, Stanislaw Gruszka <sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>> On Sat, Sep 27, 2014 at 05:11:41PM -0400, Nicholas Krause wrote:
>>>> This removes the unnecessary  overwrite of register 11 in the function,
>>>> rt2800_config_channel as we are already writing a correct value to the
>>>> register with rt2800_rfcsr_write(rt2x00dev,11.rfcsr).
>>> What make you sure that overwrite is unnecessary ?
>>>
>>>>
>>>> Signed-off-by: Nicholas Krause <yocto6-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>>> ---
>>>>  drivers/net/wireless/rt2x00/rt2800lib.c | 2 --
>>>>  1 file changed, 2 deletions(-)
>>>>
>>>> diff --git a/drivers/net/wireless/rt2x00/rt2800lib.c
>>>> b/drivers/net/wireless/rt2x00/rt2800lib.c
>>>> index 893c9d5..fb0ae38 100644
>>>> --- a/drivers/net/wireless/rt2x00/rt2800lib.c
>>>> +++ b/drivers/net/wireless/rt2x00/rt2800lib.c
>>>> @@ -2787,8 +2787,6 @@ static void rt2800_config_channel_rf55xx(struct
>>>> rt2x00_dev *rt2x00dev,
>>>>
>>>>  	if (rf->channel <= 14) {
>>>>  		rt2800_rfcsr_write(rt2x00dev, 10, 0x90);
>>>> -		/* FIXME: RF11 owerwrite ? */
>>>> -		rt2800_rfcsr_write(rt2x00dev, 11, 0x4A);
>>> We need a prove that remove is correct, i.e. some reference to
>>> vendor code or spec that current writing register twice with
>>> different values is wrong.
>>>
>>> NACK for the patch.
>>>
>>> Stanislaw
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>>> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
> I will see if I can either find the vendor code or spec in order to do this correctly. Thanks for the reply
> through.
> Nick 
> 
In addition someone banned me from the list yet again. I am getting rather annoyed with this and can someone 
please remove it.
Cheers Nick
