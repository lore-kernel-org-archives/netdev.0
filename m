From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PEERCGROUP
Date: Thu, 13 Mar 2014 11:01:14 -0700
Message-ID: <CALCETrWtVEjPGoJLe0CDuNW2cpSmh+ZvHOXJ_pLeZ=x+UUcShQ@mail.gmail.com>
References: <1394657163-7472-1-git-send-email-vgoyal@redhat.com>
 <1394657163-7472-3-git-send-email-vgoyal@redhat.com> <5320CAEC.6030008@amacapital.net>
 <CALCETrUTjN=XKwnO62P9roZtLLuk7_9Oi17Mj_Aa2ZFtZc1gVA@mail.gmail.com>
 <1394658983.32465.203.camel@willson.li.ssimo.org> <CALCETrU29CpcK4dVRD45BGOD7AVEudADiFxOgFgKWkpFzw07eg@mail.gmail.com>
 <1394673476.32465.215.camel@willson.li.ssimo.org> <CALCETrWbCuKfV4zMkZajDOGhGkKduW0C2L7uHv=vtvqhVeAc6w@mail.gmail.com>
 <1394675038.32465.223.camel@willson.li.ssimo.org> <CALCETrV7GE0YL1sDDqTUV81rWL9zk2vTR1-VLkR7CfTA-FSrgw@mail.gmail.com>
 <1394733077.32465.243.camel@willson.li.ssimo.org> <CALCETrXWzja6W6y=p9MrtynGZMsrD5KQu0KBK6Bs1dQxnesv2A@mail.gmail.com>
 <1394733526.32465.250.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vivek Goyal <vgoyal@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	cgroups@vger.kernel.org,
	Network Development <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	jkaluza@redhat.com, lpoetter@redhat.com, kay@redhat.com
To: Simo Sorce <ssorce@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394733526.32465.250.camel@willson.li.ssimo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 13, 2014 at 10:58 AM, Simo Sorce <ssorce@redhat.com> wrote:
> On Thu, 2014-03-13 at 10:55 -0700, Andy Lutomirski wrote:
>>
>> So give each container its own unix socket.  Problem solved, no?
>
> Not really practical if you have hundreds of containers.

I don't see the problem.  Sockets are cheap.

>
> Simo.
>



-- 
Andy Lutomirski
AMA Capital Management, LLC
