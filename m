From: Paul Menage <paul@paulmenage.org>
Subject: Re: [PATCH] per-cgroup tcp buffer limitation
Date: Tue, 13 Sep 2011 11:46:29 -0700
Message-ID: <CALdu-PDGpBnVHW7E5NobAwtXop5c03NTmijkk8oB7u-a5LEXww@mail.gmail.com>
References: <1315276556-10970-1-git-send-email-glommer@parallels.com>
 <CAHH2K0aJxjinSu0Ek6jzsZ5dBmm5mEU-typuwYWYWEudF2F3Qg@mail.gmail.com>
 <4E664766.40200@parallels.com> <CAHH2K0YJA7vZZ3QNAf63TZOnWhsRUwfuZYfntBL4muZ0G_Vt2w@mail.gmail.com>
 <4E66A0A9.3060403@parallels.com> <CAHH2K0aq4s1_H-yY0kA3LhM00CCNNbJZyvyBoDD6rHC+qo_gNg@mail.gmail.com>
 <4E68484A.4000201@parallels.com> <CAHH2K0YcXMUfd1Zr=f5a4=X9cPPp8NZiuichFXaOo=kVp5rRJA@mail.gmail.com>
 <4E699341.9010606@parallels.com> <CALdu-PCrYPZx38o44ZyFrbQ6H39-vNPKey_Tpm4HRUNHNFMpyA@mail.gmail.com>
 <4E6E39DD.2040102@parallels.com> <CALdu-PC7ESSUHuF4vfVoRFFfkaBt1V28rGW3-O5pT3WtegAh4g@mail.gmail.com>
 <4E6F9CC4.2000601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com,
	"David S. Miller" <davem@davemloft.net>, Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>, Suleiman Souhlal <suleiman@google.com>,
	Lennart Poettering <lennart@poettering.net>
To: Glauber Costa <glommer@parallels.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4E6F9CC4.2000601@parallels.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 13, 2011 at 11:11 AM, Glauber Costa <glommer@parallels.com> wrote:
>
> What if they are all updated under the same lock ?

Right, that would be the kind of optimization that would remove the
need for worrying about whether or not to account it. It would
probably mean creating some memcg-specific structures like
res-counters that could handle multiple values, since you'd need to
update both the kernel charge and the total charge, in this cgroup
*and* its ancestors.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
