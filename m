From: Glauber Costa <glommer@parallels.com>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Date: Tue, 6 Sep 2011 22:32:22 -0300
Message-ID: <4E66C9A6.8080804@parallels.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com> <CALdu-PDoPPdcX0bAkVpaP9R-z1yKin=JOjjT3rMuoSHJaywSCg@mail.gmail.com> <4E66C45A.8060706@parallels.com> <CALdu-PDZC3FTuR31d5+P+=U=0UFVUZD_KDEgPHBeD-MyQ4PuSQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
	<containers@lists.osdl.org>, <netdev@vger.kernel.org>, <xemul@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa
	<kamezawa.hiroyu@jp.fujitsu.com>, "Eric W. Biederman" <ebiederm@xmission.com>
To: Paul Menage <paul@paulmenage.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CALdu-PDZC3FTuR31d5+P+=U=0UFVUZD_KDEgPHBeD-MyQ4PuSQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 09/06/2011 10:29 PM, Paul Menage wrote:
> On Tue, Sep 6, 2011 at 6:09 PM, Glauber Costa<glommer@parallels.com>  wrote:
>>
>> Can you be more specific?
>
> Maybe if you include the source to kmem_cgroup.c :-)
Yeah, *facepalm*.

I am about to send another version, just finishing writing up the docs.
But it is really simple right now, and only cares about the socket 
stuff. No reporting, nothing else. My idea is we use it as a seed and 
grow it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
