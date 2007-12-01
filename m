From: "Denis V. Lunev" <den-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 4/4 (resent) net-2.6.25][UNIX] Make the unix sysctl
 tables per-namespace
Date: Sat, 01 Dec 2007 16:07:05 +0300
Message-ID: <47515C79.9060903@openvz.org>
References: <47503919.8060103@openvz.org> <47503C48.8020001@openvz.org>
	<20071201125726.GC15910@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>,
        Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20071201125726.GC15910-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Fri, Nov 30, 2007 at 07:37:28PM +0300, Pavel Emelyanov wrote:
>> Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
> 
> All applied to net-2.6.25.
> 
>> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
>> index b0cf075..f97b2a4 100644
>> --- a/include/net/net_namespace.h
>> +++ b/include/net/net_namespace.h
>> @@ -41,6 +43,7 @@ struct net {
>>  
>>  	/* unix sockets */
>>  	int			sysctl_unix_max_dgram_qlen;
>> +	struct ctl_table_header	*unix_ctl;
>>  };
> 
> But I gotta say this struct/file is going to be enormous.  It's also
> one of those files that causes everything to get recompiled.  Maybe
> we ought to make a rule that each subsystem only gets to have at most
> one entry in it :)
> 
> Thanks,

Good point, thanks. We'll start thinking in that direction. Right now it
is not finally cursed with all staff around.

Regards,
	Den
