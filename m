From: ChunYu Wang <chunwang@redhat.com>
Subject: Re: WARNING in refcount_sub_and_test
Date: Thu, 26 Oct 2017 16:53:26 +0800
Message-ID: <CAOm2TWwoJhsT==euSyC0EDCbWXzTVWBBmvbX8HgmdjxvW0wVbw@mail.gmail.com>
References: <001a11441d867b940f055c4c0b40@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: davem@davemloft.net, LKML <linux-kernel@vger.kernel.org>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        nhorman@tuxdriver.com, syzkaller-bugs@googlegroups.com,
        vyasevich@gmail.com
To: syzbot
        <bot+a004c8dcbae7c160bf1bbd6e6af2e9cf4fa54f84@syzkaller.appspotmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <001a11441d867b940f055c4c0b40@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I am failed to reproduce it on target kernel with the reproducer file
or replaying the target syzkaller description log file, do I made
something wrong or there exists more subjects then the line in
repro.txt:

#{Threaded:true Collide:true Repeat:false Procs:1 Sandbox:namespace
Fault:false FaultCall:-1 FaultNth:0 EnableTun:false UseTmpDir:true
HandleSegv:false WaitRepeat:false Debug:false Repro:false}


Thanks
- ChunYu

---
2017/10/26 04:49:15 reproducing crash 'hang': testing program
(duration=10s, {Threaded:true Collide:true Repeat:true Procs:32
Sandbox:namespace Fault:false FaultCall:-1 FaultNth:0 EnableTun:true
UseTmpDir:true HandleSegv:true WaitRepeat:true Debug:false
Repro:true}): mmap-socket$inet_sctp-listen-accept4-listen-sendto$inet
2017/10/26 04:49:15 running command: ssh []string{"-p", "22", "-o",
"ConnectionAttempts=10", "-o", "ConnectTimeout=10", "-o",
"BatchMode=yes", "-o", "UserKnownHostsFile=/dev/null", "-o",
"IdentitiesOnly=yes", "-o", "StrictHostKeyChecking=no", "-o",
"LogLevel=error", "-i", "/home/chunwang/.ssh/id_rsa",
"root@10.73.5.213", "cd /home/user/tmp/syz && exec
/home/user/tmp/syz/syz-execprog -executor
/home/user/tmp/syz/syz-executor -arch=amd64 -cover=0 -procs=32
-repeat=0 -sandbox namespace -threaded=true -collide=true
/home/user/tmp/syz/syzkaller140727249"}
2017/10/26 04:49:25 reproducing crash 'hang': program did not crash
2017/10/26 04:49:25 reproducing crash 'hang': single: failed to
extract reproducer
2017/10/26 04:49:25 reproducing crash 'hang': bisect: bisecting 1
programs with base timeout 10s
2017/10/26 04:49:25 reproducing crash 'hang': bisect: bisecting 1 programs
2017/10/26 04:49:25 reproducing crash 'hang': bisect: executing all 1 programs
