From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 3527] New: ssh does not work with 2.6.9rc3
Date: Fri, 8 Oct 2004 10:48:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041008104801.0dd96536.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: albie@alfarrabio.di.uminho.pt
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hrm.   Could you check to see if it starts working OK after the machine has been
up for more than five minutes?

Begin forwarded message:

Date: Fri, 8 Oct 2004 09:26:51 -0700
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 3527] New: ssh does not work with 2.6.9rc3


http://bugme.osdl.org/show_bug.cgi?id=3527

           Summary: ssh does not work with 2.6.9rc3
    Kernel Version: 2.6.9 RC 3
            Status: NEW
          Severity: normal
             Owner: other_other@kernel-bugs.osdl.org
         Submitter: albie@alfarrabio.di.uminho.pt


Distribution: Slackware 10

Problem Description:
 Had kernel 2.6.7 working correctly. It had a bug with my sis ethernet card.
Upgraded to 2.6.8.1, and had problems with sata (bug #3521). So, tried the 2.6.9
RC 3. 

 With this kernel, the sis ethernet bug is fixed (well, at least I can do a ping
-f without losing packets), SATA works but... wonder... ssh doesn't.

If I have a public key on other machine without passphrase, it works.
If not....

ssh_askpass: exec(/usr/libexec/ssh-askpass): No such file or directory
Permission denied, please try again.
ssh_askpass: exec(/usr/libexec/ssh-askpass): No such file or directory
Permission denied, please try again.
ssh_askpass: exec(/usr/libexec/ssh-askpass): No such file or directory
Permission denied (publickey,password,keyboard-interactive).

Now, that file really doesn't exist. But it isn't needed with the old kernel.
So, what 2.6.9 rc 3 has that 2.6.7 don't?

Thanks,
Alberto

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
