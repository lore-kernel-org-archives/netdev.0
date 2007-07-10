From: Tetsuo Handa <from-netdev@i-love.sakura.ne.jp>
Subject: Re: [RFC] Allow LSM to use IP address/port number.
Date: Tue, 10 Jul 2007 13:11:37 +0900
Message-ID: <200707100411.l6A4BbMo060033@www262.sakura.ne.jp>
References: <200707070225.AFC45609.MNStNTPG@I-love.SAKURA.ne.jp> <200707061343.03942.paul.moore@hp.com> <200707090533.l695X1PM059672@www262.sakura.ne.jp> <20070709.002629.28788394.davem@davemloft.net> <200707092213.HAC58314.WSNFtPGOFUE@I-love.SAKURA.ne.jp> <Line.LNX.4.64.0707091842360.9417@d.namei> <20070709160538.289d8ac2@freepuppy.rosehill.hemminger.net> <Line.LNX.4.64.0707091940450.10029@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: James Morris <jmorris@namei.org>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <Line.LNX.4.64.0707091940450.10029@d.namei>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for your comment.

I have a question regarding netfilter infrastructure.

I want to filter messages using "task_struct->security".
Can the netfilter's queuing to userspace feature
get a list of "struct task_struct" who shares a socket
that is going to receive incoming messages?

My approach is not "is this socket allowed to receive from xxx.xxx.xxx.xxx port yy"
but "is this process allowed to receive from xxx.xxx.xxx.xxx port yy".
So, my approach is not using security context associated with a socket
but security context associated with a process.

If I can't use netfilter, there is no chance to filter before enqueuing
messages. So, I think propagating errors to the local user
after dequeuing messages is the only possible way.

Regards.
