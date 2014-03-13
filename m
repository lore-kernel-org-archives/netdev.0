From: Carol Soto <clsoto-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [Patch 1/2] IB/mlx5: Implementation of PCI error handler
Date: Thu, 13 Mar 2014 10:12:19 -0500
Message-ID: <5321CAD3.2070301@linux.vnet.ibm.com>
References: <20140312034219.637916521@linux.vnet.ibm.com> <20140312034512.065218504@linux.vnet.ibm.com> <1394649252.23624.36.camel@deadeye.wl.decadent.org.uk> <20140313064521.GH20224@mtldesk30>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, brking-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140313064521.GH20224@mtldesk30>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


On 3/13/2014 1:45 AM, Eli Cohen wrote:
> On Wed, Mar 12, 2014 at 06:34:12PM +0000, Ben Hutchings wrote:
>>>   
>>>   enum {
>>> -       /* one minute for the sake of bringup. Generally, commands must always
>>> +       /* 10 msecs for the sake of bringup. Generally, commands must always
>>>           * complete and we may need to increase this timeout value
>>>           */
>>> -       MLX5_CMD_TIMEOUT_MSEC   = 7200 * 1000,
>>> +       MLX5_CMD_TIMEOUT_MSEC   = 10 * 1000,
>> You seem to be changing the timeout from 2 hours (not one minute) to 10
>> seconds (not milliseconds).
>>
> Thanks for noting this. Actually, the time should remain 2 hours and
> the comment should be fixed. Also note that long time/missing
> completion of a command is, genrallly, not indicative of a PCI error.
> If that happens, we would want to have enough time to do diagnostics
> before timing out.
>
Hi Eli

In mlx4 code, I do not recall a timeout for commands this big. So the 
reason in mlx5 is 2 hrs is just for
debugging purposes? So if for any reason a command hang then the user 
can not remove this module
for the next 2 hrs?

Carol

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
