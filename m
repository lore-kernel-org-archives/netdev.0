From: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Subject: Re: [patch net-next v2 0/9] introduce rocker switch
 driver with hardware accelerated datapath api
Date: Fri, 19 Sep 2014 16:20:32 +0200
Message-ID: <20140919142032.GF1980@nanopsycho.orion>
References: <1411134590-4586-1-git-send-email-jiri@resnulli.us>
 <063D6719AE5E284EB5DD2968C1650D6D17495CC6@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <ryazanov.s.a-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
 "john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org" <Neil.Jerram-QnUH15yq9NYqDJ6do+/SaQ@public.gmane.org>,
 "edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org" <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
 "andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org" <andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>,
 "dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org" <dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>,
 "nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org" <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>,
 "f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org" <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 "ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ronye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org" <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
 "ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org" <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>,
 "buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org" <buytenh-OLH4Qvv75CYX/NnBR394Jw@public.gmane.org>,
 "alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
 "simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org" <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>,
 "roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org" <roopa-qUQiAmfTcIp+XZJcv9eMoEEOCMrvLtNR@public.gmane.org>,
 "jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org" <jh
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17495CC6-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
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

Fri, Sep 19, 2014 at 04:15:32PM CEST, David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org wrote:
>From: Jiri Pirko
>> This patchset can be divided into 3 main sections:
>> - introduce switchdev api for implementing switch drivers
>> - introduce switchdev generic netlink api for userspace manipulation
>> - introduce rocker switch driver which implements switchdev api
>
>Perhaps you should be including the name of what you are switching
>in the name of the API?
>
>Is this for interfacing to ethernet switches, TDM switches or
>mechanical ones?
>It isn't really clear from any of these commit messages.

I thought that is isn't necessary, that it is clear this is about ethernet
switches.
