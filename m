From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH] vhost: replace % with & on data path
Date: Mon, 30 Nov 2015 17:00:58 +0800
Message-ID: <201511301656.vXcgCeT9%fengguang.wu@intel.com>
References: <1448872427-11623-1-git-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="vtzGhvizbBRQ85DL"
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448872427-11623-1-git-send-email-mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--vtzGhvizbBRQ85DL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Michael,

[auto build test ERROR on: v4.4-rc3]
[also build test ERROR on: next-20151127]

url:    https://github.com/0day-ci/linux/commits/Michael-S-Tsirkin/vhost-replace-with-on-data-path/20151130-163704
config: s390-performance_defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=s390 

All errors (new ones prefixed by >>):

   drivers/vhost/vhost.c: In function 'vhost_get_vq_desc':
   drivers/vhost/vhost.c:1345:6: warning: unused variable 'ret' [-Wunused-variable]
     int ret;
         ^
   drivers/vhost/vhost.c:1344:13: warning: unused variable 'ring_head' [-Wunused-variable]
     __virtio16 ring_head;
                ^
   drivers/vhost/vhost.c:1341:24: warning: unused variable 'found' [-Wunused-variable]
     unsigned int i, head, found = 0;
                           ^
   drivers/vhost/vhost.c:1341:18: warning: unused variable 'head' [-Wunused-variable]
     unsigned int i, head, found = 0;
                     ^
   drivers/vhost/vhost.c:1341:15: warning: unused variable 'i' [-Wunused-variable]
     unsigned int i, head, found = 0;
                  ^
   drivers/vhost/vhost.c:1340:20: warning: unused variable 'desc' [-Wunused-variable]
     struct vring_desc desc;
                       ^
   drivers/vhost/vhost.c: At top level:
   drivers/vhost/vhost.c:1373:2: error: expected identifier or '(' before 'if'
     if (unlikely(__get_user(ring_head,
     ^
   In file included from include/uapi/linux/stddef.h:1:0,
                    from include/linux/stddef.h:4,
                    from include/uapi/linux/posix_types.h:4,
                    from include/uapi/linux/types.h:13,
                    from include/linux/types.h:5,
                    from include/uapi/asm-generic/fcntl.h:4,
                    from arch/s390/include/uapi/asm/fcntl.h:1,
                    from include/uapi/linux/fcntl.h:4,
                    from include/linux/fcntl.h:4,
                    from include/linux/eventfd.h:11,
                    from drivers/vhost/vhost.c:14:
>> arch/s390/include/asm/uaccess.h:250:2: error: expected identifier or '(' before ')' token
    })
     ^
   include/linux/compiler.h:166:42: note: in definition of macro 'unlikely'
    # define unlikely(x) __builtin_expect(!!(x), 0)
                                             ^
   drivers/vhost/vhost.c:1373:15: note: in expansion of macro '__get_user'
     if (unlikely(__get_user(ring_head,
                  ^
   drivers/vhost/vhost.c:1381:2: warning: data definition has no type or storage class
     head = vhost16_to_cpu(vq, ring_head);
     ^
   drivers/vhost/vhost.c:1381:2: error: type defaults to 'int' in declaration of 'head' [-Werror=implicit-int]
   drivers/vhost/vhost.c:1381:24: error: 'vq' undeclared here (not in a function)
     head = vhost16_to_cpu(vq, ring_head);
                           ^
   drivers/vhost/vhost.c:1381:28: error: 'ring_head' undeclared here (not in a function)
     head = vhost16_to_cpu(vq, ring_head);
                               ^
   drivers/vhost/vhost.c:1384:2: error: expected identifier or '(' before 'if'
     if (unlikely(head >= vq->num)) {
     ^
   drivers/vhost/vhost.c:1391:2: warning: data definition has no type or storage class
     *out_num = *in_num = 0;
     ^
   drivers/vhost/vhost.c:1391:3: error: type defaults to 'int' in declaration of 'out_num' [-Werror=implicit-int]
     *out_num = *in_num = 0;
      ^
   drivers/vhost/vhost.c:1391:14: error: 'in_num' undeclared here (not in a function)
     *out_num = *in_num = 0;
                 ^
   drivers/vhost/vhost.c:1392:2: error: expected identifier or '(' before 'if'
     if (unlikely(log))
     ^
   drivers/vhost/vhost.c:1395:2: warning: data definition has no type or storage class
     i = head;
     ^
   drivers/vhost/vhost.c:1395:2: error: type defaults to 'int' in declaration of 'i' [-Werror=implicit-int]
   drivers/vhost/vhost.c:1395:2: error: initializer element is not constant
   drivers/vhost/vhost.c:1396:2: error: expected identifier or '(' before 'do'
     do {
     ^
   drivers/vhost/vhost.c:1454:4: error: expected identifier or '(' before 'while'
     } while ((i = next_desc(vq, &desc)) != -1);
       ^
   drivers/vhost/vhost.c:1457:4: error: expected '=', ',', ';', 'asm' or '__attribute__' before '->' token
     vq->last_avail_idx++;
       ^
   In file included from arch/s390/include/asm/bug.h:69:0,
                    from include/linux/bug.h:4,
                    from include/linux/thread_info.h:11,
                    from include/asm-generic/preempt.h:4,
                    from arch/s390/include/generated/asm/preempt.h:1,
                    from include/linux/preempt.h:59,
                    from include/linux/spinlock.h:50,
                    from include/linux/wait.h:8,
                    from include/linux/eventfd.h:12,
                    from drivers/vhost/vhost.c:14:
   include/asm-generic/bug.h:55:27: error: expected identifier or '(' before 'do'
    #define BUG_ON(condition) do { if (unlikely(condition)) BUG(); } while (0)
                              ^
   drivers/vhost/vhost.c:1461:2: note: in expansion of macro 'BUG_ON'
     BUG_ON(!(vq->used_flags & VRING_USED_F_NO_NOTIFY));
     ^
   include/asm-generic/bug.h:55:66: error: expected identifier or '(' before 'while'
    #define BUG_ON(condition) do { if (unlikely(condition)) BUG(); } while (0)
                                                                     ^
   drivers/vhost/vhost.c:1461:2: note: in expansion of macro 'BUG_ON'
     BUG_ON(!(vq->used_flags & VRING_USED_F_NO_NOTIFY));
     ^
   drivers/vhost/vhost.c:1462:2: error: expected identifier or '(' before 'return'
     return head;
     ^
   drivers/vhost/vhost.c:1463:1: error: expected identifier or '(' before '}' token
    }
    ^
   drivers/vhost/vhost.c:1235:12: warning: 'get_indirect' defined but not used [-Wunused-function]
    static int get_indirect(struct vhost_virtqueue *vq,
               ^
   drivers/vhost/vhost.c: In function 'vhost_get_vq_desc':
   drivers/vhost/vhost.c:1369:2: warning: control reaches end of non-void function [-Wreturn-type]
     }
     ^
   cc1: some warnings being treated as errors

vim +250 arch/s390/include/asm/uaccess.h

cfa785e62 arch/s390/include/asm/uaccess.h Heiko Carstens     2014-01-22  234  					 sizeof(*(ptr)));	\
97fa5a664 include/asm-s390/uaccess.h      Al Viro            2006-02-03  235  		(x) = *(__force __typeof__(*(ptr)) *) &__x;	\
1047aa772 include/asm-s390/uaccess.h      Martin Schwidefsky 2005-11-07  236  		break;						\
1047aa772 include/asm-s390/uaccess.h      Martin Schwidefsky 2005-11-07  237  	};							\
1047aa772 include/asm-s390/uaccess.h      Martin Schwidefsky 2005-11-07  238  	case 8: {						\
1047aa772 include/asm-s390/uaccess.h      Martin Schwidefsky 2005-11-07  239  		unsigned long long __x;				\
cfa785e62 arch/s390/include/asm/uaccess.h Heiko Carstens     2014-01-22  240  		__gu_err = __get_user_fn(&__x, ptr,		\
cfa785e62 arch/s390/include/asm/uaccess.h Heiko Carstens     2014-01-22  241  					 sizeof(*(ptr)));	\
97fa5a664 include/asm-s390/uaccess.h      Al Viro            2006-02-03  242  		(x) = *(__force __typeof__(*(ptr)) *) &__x;	\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  243  		break;						\
1047aa772 include/asm-s390/uaccess.h      Martin Schwidefsky 2005-11-07  244  	};							\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  245  	default:						\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  246  		__get_user_bad();				\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  247  		break;						\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  248  	}							\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  249  	__gu_err;						\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16 @250  })
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  251  
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  252  #define get_user(x, ptr)					\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  253  ({								\
dab4079d5 arch/s390/include/asm/uaccess.h Heiko Carstens     2009-06-12  254  	might_fault();						\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  255  	__get_user(x, ptr);					\
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  256  })
^1da177e4 include/asm-s390/uaccess.h      Linus Torvalds     2005-04-16  257  
4f41c2b45 arch/s390/include/asm/uaccess.h Heiko Carstens     2014-01-23  258  int __get_user_bad(void) __attribute__((noreturn));

:::::: The code at line 250 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--vtzGhvizbBRQ85DL
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
AAA=

--vtzGhvizbBRQ85DL--
