From: "James Kelty" <jamesk@everbase.net>
Subject: RE: amd or autofos?
Date: Tue, 16 Apr 2002 13:48:10 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <a9i2s2$3ir$2@main.gmane.org>
References: <1018961918.1358.29.camel@x2.vil.ite.mee.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: <linux-net@vger.kernel.org>, <linux-admin@vger.kernel.org>
In-Reply-To: <1018961918.1358.29.camel@x2.vil.ite.mee.com>
List-Id: netdev.vger.kernel.org

The edit would look like this.

<snip>

192.168.10.23:/export   /nfs/local/mount/directory     nfs     defaults
0 0

<snip>

-James


-----Original Message-----
From: linux-admin-owner@vger.kernel.org
[mailto:linux-admin-owner@vger.kernel.org]On Behalf Of Paul Furness
Sent: Tuesday, April 16, 2002 5:59 AM
To: linux-net@vger.kernel.org; linux-admin@vger.kernel.org
Subject: amd or autofos?


Hi, all.

Is there someone around with lots of experience of auto mounting nfs
shares on RedHat?

Here's the setup:
I have just taken over running the network and servers for this nice
company, and we currently have a number of servers (all running RedHat
6.2) that variously run NIS, apache, various databases, and lots of disk
space. The disks are shared using nfs shared, and then mounted using AMD
on whichever machine the user logs in to. This includes not only shared
volumes of data, but also the home directories of the users.

There is an ongoing problem where AMD on a random machine dies at a
random time, and has to be restarted so people can access files again.

It is my intention to upgrade all the servers to RH7.2 (I could update
the individual packages and the build a kernel, but a full upgrade seems
a whole lot simpler to manage!) and I also have the chance to update how
some of it works.

So given an unrestricted choice between ams and autofs, which would you
go for? Is autofs more stable than amd? It certainly looks to be
slightly better documented and slightly easier to configure.

Any thoughts would be appreciated.

Thanks.

BUNgle

"One of these days I'll figure how the damn thing works..."

-
To unsubscribe from this list: send the line "unsubscribe linux-admin" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

