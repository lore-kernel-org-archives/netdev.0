From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: checkpoint/restore of seccomp filters v3
Date: Wed, 30 Sep 2015 12:13:35 -0600
Message-ID: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f170.google.com ([209.85.223.170]:32881 "EHLO
	mail-io0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933160AbbI3SOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 14:14:34 -0400
Received: by iofh134 with SMTP id h134so57820291iof.0
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 11:14:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

Here's a re-worked set for c/r of seccomp filters which keeps around the
original bpf program passed to the kernel instead of trying to dump the
ebpf version. There are various comments/questions in the individual patch
notes.

I'm not sure this needs to go via net-next any more, as the impact in net/
is fairly minimal, and it seems more seccomp heavy. As such, this set is
based on seccomp/tip.

Thoughts welcome,

Tycho

P.S. Man page patches to come once we agree on the API :)
