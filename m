From: Nicolas Dichtel <nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH V3 0/6] namespaces: log namespaces per task
Date: Wed, 20 Aug 2014 19:43:30 +0200
Message-ID: <53F4DE42.40308@6wind.com>
References: <cover.1400271129.git.rgb@redhat.com>	<1400593754.15733.4.camel@flatline.rdu.redhat.com>	<20140520140146.GA8079@madcap2.tricolour.ca>	<20140819164617.GE9003@madcap2.tricolour.ca>	<8738crst5i.fsf@x220.int.ebiederm.org>
	<20140820162511.GS4462@madcap2.tricolour.ca>
Reply-To: nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-audit-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20140820162511.GS4462-bcJWsdo4jJjeVoXN4CMphl7TgLCtbB0G@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le 20/08/2014 18:25, Richard Guy Briggs a =E9crit :
> On 14/08/19, Eric W. Biederman wrote:
>> Richard Guy Briggs <rgb-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> writes:
>>
>>> On 14/05/20, Richard Guy Briggs wrote:
>>>> On 14/05/20, Eric Paris wrote:
>>>>> On Tue, 2014-05-20 at 09:12 -0400, Richard Guy Briggs wrote:
>>>>>> The purpose is to track namespaces in use by logged processes from t=
he
>>>>>> perspective of init_*_ns.
>>>
>>> (Including the Linux API list due to the additions to /proc/<pid>/ns/.
>>> Please see http://www.kernelhub.org/?p=3D2&msg=3D477668 and in particul=
ar
>>> http://www.kernelhub.org/?msg=3D477678&p=3D2 )
>>
>> Sigh if you have to use something like this use the proc inode
>> number.  It is the same thing.
>>
>> I hate to claim it is unique absent of the proc superblock but it is and
>> will be for the forseable future.
>>
>> It would be better to include the block device number that appears in
>> proc of 3h of the primary mount of to qualify the number.  But it is not
>> particularly important.  Coming up with an additional unique number that
>> needs to be maintained seems stronlgy silly.
>
> I am reading a contradiction here:
> 	https://www.redhat.com/archives/linux-audit/2013-March/msg00032.html
>
> and this posting went completely ignored:
> 	https://www.redhat.com/archives/linux-audit/2014-January/msg00180.html
>
> And then there was this patchset and thread where there was some good
> discussion to clarify the use case:
> 	https://lkml.org/lkml/2014/4/22/662
>
> Then V2:
> 	https://lkml.org/lkml/2014/5/9/637
>
> Then V3 3 months ago:
> 	https://www.redhat.com/archives/linux-audit/2014-May/msg00071.html
>
> I'm about to post another version of the patchset addressing Eric Paris'
> concerns about record types, field naming...
I also try to find a solution to identify netns in userland to solve
some network problems (see =

http://thread.gmane.org/gmane.linux.network/315933/focus=3D321753).

This serial number solution may be reused for this.
We really need to find a way to solve this.


Regards,
Nicolas
