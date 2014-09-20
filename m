From: Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Subject: Re: [patch net-next v2 8/9] switchdev: introduce Netlink
	API
Date: Sat, 20 Sep 2014 05:51:23 -0700
Message-ID: <541D784B.6030302@cumulusnetworks.com>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <1411134590-4586-9-git-send-email-jiri@resnulli.us>
 <541C4AFC.8060500@mojatatu.com> <20140919154946.GH1980@nanopsycho.orion>
 <541CF75C.9030209@cumulusnetworks.com>
 <DDC24110-C3F5-470F-B9BE-1D1792415D1E@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org,
 dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
 Shrijeet Mukherjee <shm-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>, ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org,
 buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org, alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
 Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>, simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org,
 Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>, aviadr-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
 nicolas.dichtel-pdR9zngts4EAvxtiuMwx3w@public.gmane.org, vyasevic-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
 netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org,
 dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Scott Feldman <sfeldma-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <DDC24110-C3F5-470F-B9BE-1D1792415D1E-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 9/20/14, 1:10 AM, Scott Feldman wrote:
> On Sep 19, 2014, at 8:41 PM, Roopa Prabhu <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org> wro=
te:
>
>> On 9/19/14, 8:49 AM, Jiri Pirko wrote:
>>> Fri, Sep 19, 2014 at 05:25:48PM CEST, jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org wrote:
>>>> On 09/19/14 09:49, Jiri Pirko wrote:
>>>>> This patch exposes switchdev API using generic Netlink.
>>>>> Example userspace utility is here:
>>>>> https://github.com/jpirko/switchdev
>>>>>
>>>> Is this just a temporary test tool? Otherwise i dont see reason
>>>> for its existence (or the API that it feeds on).
>>> Please read the conversation I had with Pravin and Jesse in v1 thread.
>>> Long story short they like to have the api separated from ovs datapath
>>> so ovs daemon can use it to directly communicate with driver. Also John
>>> Fastabend requested a way to work with driver flows without using ovs ->
>>> that was the original reason I created switchdev genl api.
>>>
>>> Regarding the "sw" tool, yes it is for testing purposes now. ovs daemon
>>> will use directly switchdev genl api.
>>>
>>> I hope I cleared this out.
>> We already have all the needed rtnetlink kernel api and userspace tools =
around it to support all
>> switching asic features. ie, the rtnetlink api is the switchdev api. We =
can do l2, l3, acl's with it.
>> Its unclear to me why we need another new netlink api. Which will mean n=
one of the existing tools to
>> create bridges etc will work on a switchdev.
>> Which seems like going in the direction exactly opposite to what we had =
discussed earlier.
> Existing rtnetlink isn=92t available to swdev without some kind of snoopi=
ng the echoes from the various kernel components (bridge, fib, etc).  With =
swdev_flow, as Jiri has defined it, there is an additional conversion neede=
d to bridge the gap (bad expression, I know) between rtnetlink and swdev_fl=
ow.  This conversion happens in the kernel components.  For example, the br=
idge module, still driven from userspace by existing rtnetlink, will formul=
ate the necessary swdev_flow insert/remove calls to the swdev driver such t=
hat HW will offload the fwd path.
>
> You have:
>      user -> rtnetlink -> kernel -> netlink echo -> [some process] -> [so=
me driver] -> HW
>
> Jiri has:
>      user -> rtnetlink -> kernel -> swdev_* -> swdev driver -> HW
>
Keeping the goal to not change or not add a new userspace API in mind,

I have :
     user -> rtnetlink -> kernel -> ndo_op -> swdev driver  -> HW

Jiri has:
     user -> genl (newapi) -> kernel -> swdev_* -> swdev driver -> HW
